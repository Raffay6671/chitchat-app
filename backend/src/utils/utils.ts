
export function getRootDir( filePath: string) {
    let index = filePath.lastIndexOf("/src");
    if (index === -1) {
      return filePath;
    }
    return filePath.substring(0, index);
  }